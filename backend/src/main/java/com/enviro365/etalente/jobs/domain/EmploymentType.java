package com.enviro365.etalente.jobs.domain;

/**
 * Employment type for a job posting.
 *
 * <p>Kept as an enum so filters are type-safe. The wire value (see
 * {@link #wire()}) matches the spec's string format (e.g. {@code "Full-time"}).</p>
 */
public enum EmploymentType {

    FULL_TIME("Full-time"),
    CONTRACT("Contract"),
    PART_TIME("Part-time"),
    INTERNSHIP("Internship");

    private final String wire;

    EmploymentType(String wire) {
        this.wire = wire;
    }

    public String wire() {
        return wire;
    }

    /**
     * Parses the wire value case-insensitively. Accepts either the enum name
     * ({@code FULL_TIME}) or the wire form ({@code "Full-time"}).
     */
    public static EmploymentType fromWire(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Employment type must not be blank");
        }
        for (EmploymentType t : values()) {
            if (t.wire.equalsIgnoreCase(value) || t.name().equalsIgnoreCase(value)) {
                return t;
            }
        }
        throw new IllegalArgumentException("Unknown employment type: " + value);
    }
}
