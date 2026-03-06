import { cn } from "../components/ui/utils";

export function ErrorBanner({
  title = "Error",
  message,
  className,
}: {
  title?: string;
  message: string;
  className?: string;
}) {
  return (
    <div
      className={cn(
        "rounded-lg border border-destructive/30 bg-destructive/10 px-4 py-3 text-sm",
        className,
      )}
      role="alert"
    >
      <div className="font-semibold">{title}</div>
      <div className="text-muted-foreground">{message}</div>
    </div>
  );
}
