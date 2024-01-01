import { CookieOptions, createServerClient } from "@supabase/ssr";
import { NextResponse } from "next/server";

import type { NextRequest } from "next/server";
import { createClient } from "./utils/supabase/middleware";

export async function middleware(request: NextRequest) {
  // This `try/catch` block is only here for the interactive tutorial.
  // Feel free to remove once you have Supabase connected.
  const { supabase, response } = createClient(request);

  // Refresh session if expired - required for Server Components
  // https://supabase.com/docs/guides/auth/auth-helpers/nextjs#managing-session-with-middleware
  await supabase.auth.getSession();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  // if user is signed in and the current path is / redirect the user to /account
  if (user && request.nextUrl.pathname === "/login") {
    return NextResponse.redirect(new URL("/", request.url));
  }

  // if user is not signed in and the current path is not / redirect the user to /
  if (!user && request.nextUrl.pathname === "/") {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * Feel free to modify this pattern to include more paths.
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
};
