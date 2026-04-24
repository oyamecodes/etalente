package com.enviro365.etalente.common.web;

import java.util.List;

/**
 * Generic pagination envelope used for list endpoints.
 *
 * @param content    the page of items.
 * @param page       zero-based page index that was returned.
 * @param size       the requested page size.
 * @param total      total number of items matching the underlying query
 *                   (not just the returned page).
 * @param totalPages derived: {@code ceil(total / size)}. Returned for
 *                   client convenience so the UI doesn't need to
 *                   re-derive the pager length.
 */
public record PageResponse<T>(
        List<T> content,
        int page,
        int size,
        long total,
        int totalPages) {

    public static <T> PageResponse<T> of(List<T> content, int page, int size, long total) {
        int pages = size <= 0 ? 0 : (int) Math.ceil(total / (double) size);
        return new PageResponse<>(content, page, size, total, pages);
    }
}
