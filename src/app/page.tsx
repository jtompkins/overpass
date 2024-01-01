import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/utils/supabase/server';

export default async function Home() {
  const cookieStore = cookies();
  const supabase = createClient(cookieStore);

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const signOut = async () => {
    'use server';

    const cookieStore = cookies();
    const supabase = createClient(cookieStore);
    await supabase.auth.signOut();
    return redirect('/login');
  };

  return user ? (
    <>
      <h1 className="text-3xl font-bold underline">Hello world!</h1>

      <div className="flex items-center gap-4">
        Hey, {user.email}!
        <form action={signOut}>
          <button>Logout</button>
        </form>
      </div>
    </>
  ) : (
    <Link href="/login">Login</Link>
  );
}
