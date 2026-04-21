package com.enviro365.etalente.common.web;

import java.util.List;

/**
 * Generic pagination envelope used for list endpoints.
 *
 * @param content  the page of items.
 * @param page     zero-based page index that was returned.
 * @param size     the requested page size.
 * @param total    total number of items matching the underlying query
 *                 (not just the returned page).
 */
public record PageResponse<T>(List<T> content, int page, int size, long total) {

    public static <T> PageResponse<T> of(List<T> content, int page, int size, long total) {
        return new PageResponse<>(content, page, size, total);
    }
}
