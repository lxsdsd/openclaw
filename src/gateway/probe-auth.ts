import type { OpenClawConfig } from "../config/config.js";
import { resolveGatewayCredentialsWithSecretInputs } from "./call.js";
import {
  type ExplicitGatewayAuth,
  isGatewaySecretRefUnavailableError,
  resolveGatewayProbeCredentialsFromConfig,
} from "./credentials.js";
import {
  preferStoredOperatorDeviceToken,
  resolveStoredOperatorDeviceToken,
} from "./operator-device-auth.js";

function buildGatewayProbeCredentialPolicy(params: {
  cfg: OpenClawConfig;
  mode: "local" | "remote";
  env?: NodeJS.ProcessEnv;
  explicitAuth?: ExplicitGatewayAuth;
}) {
  return {
    config: params.cfg,
    cfg: params.cfg,
    env: params.env,
    explicitAuth: params.explicitAuth,
    modeOverride: params.mode,
    mode: params.mode,
    includeLegacyEnv: false,
    remoteTokenFallback: "remote-only" as const,
  };
}

export function resolveGatewayProbeAuth(params: {
  cfg: OpenClawConfig;
  mode: "local" | "remote";
  env?: NodeJS.ProcessEnv;
}): { token?: string; password?: string } {
  const policy = buildGatewayProbeCredentialPolicy(params);
  const storedOperatorToken =
    params.mode === "local" ? resolveStoredOperatorDeviceToken(params.env) : undefined;
  return preferStoredOperatorDeviceToken({
    auth: storedOperatorToken
      ? { token: storedOperatorToken }
      : resolveGatewayProbeCredentialsFromConfig(policy),
    env: params.env,
    preferStoredDeviceToken: params.mode === "local",
  });
}

export async function resolveGatewayProbeAuthWithSecretInputs(params: {
  cfg: OpenClawConfig;
  mode: "local" | "remote";
  env?: NodeJS.ProcessEnv;
  explicitAuth?: ExplicitGatewayAuth;
}): Promise<{ token?: string; password?: string }> {
  const policy = buildGatewayProbeCredentialPolicy(params);
  const storedOperatorToken =
    params.mode === "local" && !(policy.explicitAuth?.token || policy.explicitAuth?.password)
      ? resolveStoredOperatorDeviceToken(params.env)
      : undefined;
  return preferStoredOperatorDeviceToken({
    auth: storedOperatorToken
      ? { token: storedOperatorToken }
      : await resolveGatewayCredentialsWithSecretInputs({
          config: policy.config,
          env: policy.env,
          explicitAuth: policy.explicitAuth,
          modeOverride: policy.modeOverride,
          includeLegacyEnv: policy.includeLegacyEnv,
          remoteTokenFallback: policy.remoteTokenFallback,
        }),
    explicitAuth: policy.explicitAuth,
    env: params.env,
    preferStoredDeviceToken: params.mode === "local",
  });
}

export function resolveGatewayProbeAuthSafe(params: {
  cfg: OpenClawConfig;
  mode: "local" | "remote";
  env?: NodeJS.ProcessEnv;
}): {
  auth: { token?: string; password?: string };
  warning?: string;
} {
  try {
    return { auth: resolveGatewayProbeAuth(params) };
  } catch (error) {
    if (!isGatewaySecretRefUnavailableError(error)) {
      throw error;
    }
    return {
      auth: {},
      warning: `${error.path} SecretRef is unresolved in this command path; probing without configured auth credentials.`,
    };
  }
}
