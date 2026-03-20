import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { storeDeviceAuthToken } from "../infra/device-auth-store.js";
import { loadOrCreateDeviceIdentity } from "../infra/device-identity.js";
import { captureEnv } from "../test-utils/env.js";
import { preferStoredOperatorDeviceToken } from "./operator-device-auth.js";

async function createStateDirWithOperatorToken(token: string) {
  const stateDir = await fs.mkdtemp(path.join(os.tmpdir(), "openclaw-operator-auth-"));
  const identityPath = path.join(stateDir, "identity", "device.json");
  const identity = loadOrCreateDeviceIdentity(identityPath);
  storeDeviceAuthToken({
    deviceId: identity.deviceId,
    role: "operator",
    token,
    env: { OPENCLAW_STATE_DIR: stateDir } as NodeJS.ProcessEnv,
  });
  return stateDir;
}

describe("preferStoredOperatorDeviceToken", () => {
  let envSnapshot = captureEnv(["OPENCLAW_STATE_DIR"]);

  afterEach(async () => {
    envSnapshot.restore();
    envSnapshot = captureEnv(["OPENCLAW_STATE_DIR"]);
  });

  it("prefers the stored operator token over ambient shared auth when enabled", async () => {
    const stateDir = await createStateDirWithOperatorToken("device-token");
    process.env.OPENCLAW_STATE_DIR = stateDir;

    const resolved = preferStoredOperatorDeviceToken({
      auth: { token: "env-token", password: "env-password" },
      preferStoredDeviceToken: true,
    });

    expect(resolved).toEqual({ token: "device-token", password: undefined });
  });

  it("keeps explicit auth untouched", async () => {
    const stateDir = await createStateDirWithOperatorToken("device-token");
    process.env.OPENCLAW_STATE_DIR = stateDir;

    const resolved = preferStoredOperatorDeviceToken({
      auth: { token: "env-token" },
      explicitAuth: { token: "explicit-token" },
      preferStoredDeviceToken: true,
    });

    expect(resolved).toEqual({ token: "env-token", password: undefined });
  });

  it("keeps resolved auth when no stored operator token exists", () => {
    const resolved = preferStoredOperatorDeviceToken({
      auth: { token: "env-token", password: "env-password" },
      preferStoredDeviceToken: true,
      env: { OPENCLAW_STATE_DIR: "/tmp/nonexistent-openclaw-operator-auth" } as NodeJS.ProcessEnv,
    });

    expect(resolved).toEqual({ token: "env-token", password: "env-password" });
  });
});
