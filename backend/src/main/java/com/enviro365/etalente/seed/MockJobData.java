package com.enviro365.etalente.seed;

import java.time.LocalDate;
import java.util.List;

import com.enviro365.etalente.jobs.domain.EmploymentType;
import com.enviro365.etalente.jobs.domain.Job;

/**
 * Hardcoded mock job listings used by the in-memory repository. Kept in its
 * own class so swapping the data source (e.g. a JSON file or a real DB) is a
 * single-point change.
 */
public final class MockJobData {

    private MockJobData() {
    }

    public static List<Job> jobs() {
        return List.of(
                Job.builder()
                        .id("job-1")
                        .title("Senior Software Engineer (Full Stack)")
                        .location("Cape Town, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("5+ Years")
                        .minYearsExperience(5)
                        .salaryRange("R85k - R120k")
                        .postedBy("Recruitment Team")
                        .closingDate(LocalDate.of(2026, 5, 24))
                        .description("""
                                Build and maintain the core talent platform.
                                Flutter on the client, Spring Boot on the server,
                                Postgres and event-driven integrations in between.""")
                        .skills(List.of("Java", "Spring Boot", "Flutter", "PostgreSQL", "AWS"))
                        .build(),
                Job.builder()
                        .id("job-2")
                        .title("Flutter Mobile Engineer")
                        .location("Remote, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("3+ Years")
                        .minYearsExperience(3)
                        .salaryRange("R55k - R80k")
                        .postedBy("Talent Acquisition")
                        .closingDate(LocalDate.of(2026, 6, 10))
                        .description("Own the iOS and Android experience for the eTalente app.")
                        .skills(List.of("Flutter", "Dart", "Riverpod", "REST"))
                        .build(),
                Job.builder()
                        .id("job-3")
                        .title("Backend Engineer (Java)")
                        .location("Johannesburg, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("4+ Years")
                        .minYearsExperience(4)
                        .salaryRange("R70k - R95k")
                        .postedBy("Recruitment Team")
                        .closingDate(LocalDate.of(2026, 5, 30))
                        .description("Ship resilient REST APIs on Spring Boot 3 and Java 21.")
                        .skills(List.of("Java", "Spring Boot", "Kafka", "PostgreSQL"))
                        .build(),
                Job.builder()
                        .id("job-4")
                        .title("DevOps Engineer")
                        .location("Centurion, ZA")
                        .type(EmploymentType.CONTRACT)
                        .experience("5+ Years")
                        .minYearsExperience(5)
                        .salaryRange("R700 - R900 / hr")
                        .postedBy("Platform Team")
                        .closingDate(LocalDate.of(2026, 5, 18))
                        .description("Harden our CI/CD and Kubernetes footprint.")
                        .skills(List.of("Kubernetes", "Terraform", "GitHub Actions", "AWS"))
                        .build(),
                Job.builder()
                        .id("job-5")
                        .title("Product Designer")
                        .location("Cape Town, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("2+ Years")
                        .minYearsExperience(2)
                        .salaryRange("R45k - R65k")
                        .postedBy("Design Guild")
                        .closingDate(LocalDate.of(2026, 6, 5))
                        .description("Design the end-to-end recruiter and candidate flows.")
                        .skills(List.of("Figma", "User Research", "Design Systems"))
                        .build(),
                Job.builder()
                        .id("job-6")
                        .title("Data Engineer")
                        .location("Remote, ZA")
                        .type(EmploymentType.CONTRACT)
                        .experience("4+ Years")
                        .minYearsExperience(4)
                        .salaryRange("R650 - R850 / hr")
                        .postedBy("Analytics Team")
                        .closingDate(LocalDate.of(2026, 5, 28))
                        .description("Build the talent analytics warehouse on dbt and Snowflake.")
                        .skills(List.of("SQL", "dbt", "Snowflake", "Airflow"))
                        .build(),
                Job.builder()
                        .id("job-7")
                        .title("QA Automation Engineer")
                        .location("Pretoria, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("3+ Years")
                        .minYearsExperience(3)
                        .salaryRange("R40k - R60k")
                        .postedBy("Quality Guild")
                        .closingDate(LocalDate.of(2026, 6, 15))
                        .description("Extend our Playwright and JUnit coverage across the stack.")
                        .skills(List.of("Playwright", "JUnit", "CI/CD"))
                        .build(),
                Job.builder()
                        .id("job-8")
                        .title("Technical Recruiter")
                        .location("Cape Town, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("2+ Years")
                        .minYearsExperience(2)
                        .salaryRange("R35k - R55k")
                        .postedBy("People Operations")
                        .closingDate(LocalDate.of(2026, 6, 20))
                        .description("Own the engineering hiring pipeline end-to-end.")
                        .skills(List.of("Sourcing", "Interviewing", "ATS"))
                        .build(),
                Job.builder()
                        .id("job-9")
                        .title("Junior Frontend Developer")
                        .location("Durban, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("1+ Years")
                        .minYearsExperience(1)
                        .salaryRange("R25k - R40k")
                        .postedBy("Recruitment Team")
                        .closingDate(LocalDate.of(2026, 7, 1))
                        .description("Level up on React and Flutter web while pairing with seniors.")
                        .skills(List.of("React", "TypeScript", "CSS"))
                        .build(),
                Job.builder()
                        .id("job-10")
                        .title("Engineering Manager")
                        .location("Johannesburg, ZA")
                        .type(EmploymentType.FULL_TIME)
                        .experience("7+ Years")
                        .minYearsExperience(7)
                        .salaryRange("R110k - R150k")
                        .postedBy("Leadership")
                        .closingDate(LocalDate.of(2026, 5, 22))
                        .description("Lead two delivery squads and own the platform roadmap.")
                        .skills(List.of("Leadership", "Architecture", "Coaching"))
                        .build(),
                Job.builder()
                        .id("job-11")
                        .title("Security Engineer")
                        .location("Remote, ZA")
                        .type(EmploymentType.CONTRACT)
                        .experience("5+ Years")
                        .minYearsExperience(5)
                        .salaryRange("R750 - R950 / hr")
                        .postedBy("Security Guild")
                        .closingDate(LocalDate.of(2026, 6, 8))
                        .description("Threat-model and harden the talent platform end-to-end.")
                        .skills(List.of("AppSec", "OWASP", "Cloud Security"))
                        .build(),
                Job.builder()
                        .id("job-12")
                        .title("Frontend Developer Intern")
                        .location("Cape Town, ZA")
                        .type(EmploymentType.INTERNSHIP)
                        .experience("0+ Years")
                        .minYearsExperience(0)
                        .salaryRange("R15k - R20k")
                        .postedBy("People Operations")
                        .closingDate(LocalDate.of(2026, 7, 12))
                        .description("12-month internship with a clear path to a permanent role.")
                        .skills(List.of("HTML", "CSS", "JavaScript"))
                        .build());
    }
}
