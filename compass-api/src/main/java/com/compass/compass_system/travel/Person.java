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
}
