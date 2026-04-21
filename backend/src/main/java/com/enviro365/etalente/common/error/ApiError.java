package com.enviro365.etalente.common.error;

import java.time.Instant;
import java.util.List;

/**
 * Canonical error payload returned by {@link GlobalExceptionHandler} and the
 * authentication entry points. Kept intentionally small so the client sees a
 * stable shape regardless of what went wrong.
 */
public record ApiError(
        Instant timestamp,
        int status,
        String error,
        String message,
        String path,
        List<FieldIssue> fieldErrors) {

    public static ApiError of(int status, String error, String message, String path) {
        return new ApiError(Instant.now(), status, error, message, path, null);
    }

    public static ApiError of(int status, String error, String message, String path,
                              List<FieldIssue> fieldErrors) {
        return new ApiError(Instant.now(), status, error, message, path, fieldErrors);
    }

    public record FieldIssue(String field, String message) {
    }
}
