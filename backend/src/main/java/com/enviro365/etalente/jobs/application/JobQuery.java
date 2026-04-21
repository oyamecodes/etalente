package com.enviro365.etalente.jobs.application;

/**
 * Criteria bundle for listing jobs. All fields are optional; {@code null}
 * or blank values mean "no filter on this field".
 *
 * @param type       employment type wire value (e.g. {@code "Full-time"},
 *                   {@code "Contract"}).
 * @param experience minimum years of experience, expressed either as the
 *                   wire string (e.g. {@code "3+ Years"}) or a plain
 *                   integer (e.g. {@code "3"}).
 * @param location   location substring (case-insensitive, trimmed).
 * @param search     free-text query matched against title, location, and
 *                   skills.
 * @param page       zero-based page index (clamped to >= 0).
 * @param size       page size (clamped to [1, 100]).
 */
public record JobQuery(
        String type,
        String experience,
        String location,
        String search,
        int page,
        int size) {

    public static final int MAX_PAGE_SIZE = 100;
    public static final int DEFAULT_PAGE_SIZE = 20;

    public JobQuery {
        if (page < 0) {
            page = 0;
        }
        if (size <= 0) {
            size = DEFAULT_PAGE_SIZE;
        } else if (size > MAX_PAGE_SIZE) {
            size = MAX_PAGE_SIZE;
        }
    }
}
