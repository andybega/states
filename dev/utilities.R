#### Duration counter
.duration_counter <- function(x, type = "event") {
  # At the end of this period, how much time has it been since last event,
  # including any this period?
  if (any(is.na(x))) stop("Missing values in x")
  duration <- vector("integer", length = length(x))
  for (i in seq_along(duration)) {
    if (i==1) { duration[i] <- 1 - x[i]; next }
    if (x[i]==0) {
      duration[i] <- duration[i-1] + 1
    } else {
      duration[i] <- 0
    }
  }
  duration
}
