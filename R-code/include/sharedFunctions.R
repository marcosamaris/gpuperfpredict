# Functions

normalizeLog <- function(x) {
    return (log(x + 0.000000000000001))
}

normalizeLogPow <- function(x){
    return(log((x + 0.000000000000001))^2)
}

normalizeLogScale <- function(x){
    log(x + 0.000000000000001)
    return(scale(x,center = TRUE, scale = TRUE))
}

normalizeLogMax <- function(x){
    return(log(x + 0.000000000000001)/max(log(x + 0.000000000000001)))
}

normalizeLogMaxPow <- function(x){
    return((log(x + 0.000000000000001)/max(log(x + 0.000000000000001)))^2)
}

normalizeLogMaxSqrt <- function(x){
    return(sqrt(log(x + 0.000000000000001)/max(log(x + 0.000000000000001))))
}


normalizeMax <- function(x) {
    return (x/max(x))
}

normalizeMaxLog <- function(x) {
    return (log(x/max(x) + 0.000000000000001))
}

normalizeMaxPow <- function(x) {
    return ((x/max(x))^2)
}

normalizeMaxSqrt <- function(x) {
    return (sqrt(x/max(x)))
}


normalizeMinMax <- function(x) {
    return ((x - min(x)) / (max(x) - min(x)))
}


normalizeExp <- function(x){
    return(exp((x/max(x))))
}

normalizeInverse <- function(x){
    return(exp((1/x)))
}

# 
# removeOutliers <- function(x){
#     intervalQuantile <- summary(sort(x))[5] - summary(sort(x))[2]
# }


