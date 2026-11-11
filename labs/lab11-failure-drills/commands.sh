# Lab 11 · Failure drills
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Watching failures
# useful while the drills run
kubectl get pods -w
kubectl describe pod -l app=vllm | tail -30
kubectl logs -l app=vllm --tail=50 -f
kubectl rollout history deploy/vllm
kubectl rollout undo deploy/vllm
kubectl get events --sort-by=.lastTimestamp | tail -20
