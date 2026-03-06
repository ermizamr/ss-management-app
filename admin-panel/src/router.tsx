import {
  createBrowserRouter,
  Navigate,
  RouterProvider,
} from "react-router";

import { RequireAuth } from "./layout/RequireAuth";
import { AdminLayout } from "./layout/AdminLayout";
import { SignInPage } from "./pages/SignInPage";
import { AcademicYearsPage } from "./pages/AcademicYearsPage";
import { UsersPage } from "./pages/UsersPage";
import { GradesPage } from "./pages/GradesPage";
import { SubjectsPage } from "./pages/SubjectsPage";
import { PromotionsPage } from "./pages/PromotionsPage";
import { AnnouncementsPage } from "./pages/AnnouncementsPage";
import { ServantsPage } from "./pages/ServantsPage";

const router = createBrowserRouter([
  { path: "/sign-in", element: <SignInPage /> },
  {
    element: <RequireAuth />,
    children: [
      {
        element: <AdminLayout />,
        children: [
          { index: true, element: <Navigate to="/admin/academic-year" replace /> },

          // Admin routes
          { path: "/admin/users", element: <UsersPage /> },
          { path: "/admin/servants", element: <ServantsPage /> },
          { path: "/admin/academic-year", element: <AcademicYearsPage /> },
          { path: "/admin/promotions", element: <PromotionsPage /> },
          { path: "/admin/announcements", element: <AnnouncementsPage /> },
          { path: "/admin/grades", element: <GradesPage /> },
          { path: "/admin/subjects", element: <SubjectsPage /> },

          // Back-compat redirects
          { path: "/academic-years", element: <Navigate to="/admin/academic-year" replace /> },
          { path: "/users", element: <Navigate to="/admin/users" replace /> },
          { path: "/grades", element: <Navigate to="/admin/grades" replace /> },
          { path: "/subjects", element: <Navigate to="/admin/subjects" replace /> },
        ],
      },
    ],
  },
  {
    path: "*",
    element: (
      <div className="min-h-svh flex items-center justify-center text-sm text-muted-foreground">
        Not found
      </div>
    ),
  },
]);

export function AppRouter() {
  return <RouterProvider router={router} />;
}
