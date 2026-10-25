package com.compass.compass_system.travel;

import jakarta.persistence.*;

@Entity
public class Person {

    @Id
    private String id;

    private String name;
    private String age;
    private String sex;

    // Index (1-based) of the participant's character in the apps' avatar catalog
    // (assets/avatars/animal_<n>.png). Only the index is stored; null = no
    // character. The catalog is append-only, so a stored value never changes meaning.
    private Integer avatarIndex;

    // Free-text observations about the participant (e.g. food intolerance,
    // mobility), written by the agent and read-only for the client. Null = no note.
    @Column(length = NOTE_MAX_LENGTH)
    private String note;

    public static final int NOTE_MAX_LENGTH = 2000;

    @PrePersist
    private void ensureId() {
        if (this.id == null || this.id.isBlank()) {
            this.id = java.util.UUID.randomUUID().toString();
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAge() { return age; }
    public void setAge(String age) { this.age = age; }

    public String getSex() { return sex; }
    public void setSex(String sex) { this.sex = sex; }

    public Integer getAvatarIndex() { return avatarIndex; }
    public void setAvatarIndex(Integer avatarIndex) {
        // Indexes start at 1; anything lower is stored as "no character".
        this.avatarIndex = avatarIndex != null && avatarIndex >= 1 ? avatarIndex : null;
    }

    public String getNote() { return note; }
    public void setNote(String note) {
        // Blank means "no note"; longer text is cut to the column size instead of failing the whole PUT.
        String trimmed = note == null ? "" : note.trim();
        this.note = trimmed.isEmpty() ? null
                : trimmed.substring(0, Math.min(trimmed.length(), NOTE_MAX_LENGTH));
    }
}
