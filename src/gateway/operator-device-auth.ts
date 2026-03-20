import path from "node:path";
import { resolveStateDir } from "../config/paths.js";
import { loadDeviceAuthToken } from "../infra/device-auth-store.js";
import { loadOrCreateDeviceIdentity } from "../infra/device-identity.js";
import { trimToUndefined, type ExplicitGatewayAuth } from "./credentials.js";

export type GatewayResolvedAuth = {
  token?: string;
  password?: string;
};

function resolveDeviceIdentityPath(env: NodeJS.ProcessEnv): string {
  return path.join(resolveStateDir(env), "identity", "device.json");
}

export function resolveStoredOperatorDeviceToken(
  env: NodeJS.ProcessEnv = process.env,
): string | undefined {
  const identity = loadOrCreateDeviceIdentity(resolveDeviceIdentityPath(env));
  return (
    loadDeviceAuthToken({
      deviceId: identity.deviceId,
      role: "operator",
      env,
    })?.token ?? undefined
  );
}

export function preferStoredOperatorDeviceToken(params: {
  auth: GatewayResolvedAuth;
  explicitAuth?: ExplicitGatewayAuth;
  env?: NodeJS.ProcessEnv;
  preferStoredDeviceToken?: boolean;
}): GatewayResolvedAuth {
  const env = params.env ?? process.env;
  const resolvedAuth: GatewayResolvedAuth = {
    token: trimToUndefined(params.auth.token),
    password: trimToUndefined(params.auth.password),
  };
  if (!params.preferStoredDeviceToken) {
    return resolvedAuth;
  }

  const explicitToken = trimToUndefined(params.explicitAuth?.token);
  const explicitPassword = trimToUndefined(params.explicitAuth?.password);
  if (explicitToken || explicitPassword) {
    return resolvedAuth;
  }

  const storedOperatorToken = trimToUndefined(resolveStoredOperatorDeviceToken(env));
  if (!storedOperatorToken) {
    return resolvedAuth;
  }

  // Local operator commands should prefer the paired device token over ambient
  // shared gateway tokens so they keep operator scopes across command paths.
  return { token: storedOperatorToken, password: undefined };
}
