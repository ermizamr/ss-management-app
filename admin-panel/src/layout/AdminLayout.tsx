import { NavLink, Outlet } from "react-router";

import { Button } from "../components/ui/button";
import { Separator } from "../components/ui/separator";
import { useAuth } from "../auth/AuthProvider";

const navItems = [
  { to: "/admin/users", label: "Users" },
  { to: "/admin/servants", label: "Servants" },
  { to: "/admin/academic-year", label: "Academic Year" },
  { to: "/admin/promotions", label: "Promotions" },
  { to: "/admin/announcements", label: "Announcements" },
  { to: "/admin/grades", label: "Grades" },
  { to: "/admin/subjects", label: "Subjects" },
] as const;

export function AdminLayout() {
  const { user, signOut } = useAuth();

  return (
    <div className="min-h-svh bg-background text-foreground">
      <div className="mx-auto grid max-w-6xl grid-cols-1 gap-6 px-4 py-6 md:grid-cols-[240px_1fr]">
        <aside className="bg-card rounded-xl border p-4">
          <div className="flex items-center justify-between gap-3">
            <div className="text-sm font-semibold">Admin Panel</div>
            <Button variant="outline" size="sm" onClick={() => void signOut()}>
              Sign out
            </Button>
          </div>
          <div className="mt-2 text-xs text-muted-foreground break-all">
            {user?.email ?? user?.id}
          </div>

          <Separator className="my-4" />

          <nav className="flex flex-col gap-1">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  [
                    "rounded-md px-3 py-2 text-sm transition-colors",
                    isActive
                      ? "bg-accent text-accent-foreground"
                      : "hover:bg-accent/60",
                  ].join(" ")
                }
              >
                {item.label}
              </NavLink>
            ))}
          </nav>
        </aside>

        <main className="min-w-0">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
