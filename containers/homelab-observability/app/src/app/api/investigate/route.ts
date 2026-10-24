import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => ({}));
  const upstream = process.env.OPENSRE_URL ?? "https://opensre.kien.cc";
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 120_000);
  try {
    const response = await fetch(`${upstream}/investigate`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        raw_alert: { title: body.title ?? "Homelab anomaly", message: body.message ?? "Investigate the current infrastructure anomaly" },
        alert_name: body.title ?? "Homelab anomaly",
        severity: body.severity ?? "warning",
      }),
      cache: "no-store",
      signal: controller.signal,
    });
    const payload = await response.json().catch(() => ({ error: "Invalid OpenSRE response" }));
    return NextResponse.json(payload, { status: response.status });
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : "OpenSRE unavailable" }, { status: 502 });
  } finally { clearTimeout(timer); }
}
