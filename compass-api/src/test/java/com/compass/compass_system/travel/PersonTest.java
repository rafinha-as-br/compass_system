package com.compass.compass_system.travel;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class PersonTest {

    @Test
    void avatarIndexKeepsValidIndexes() {
        Person person = new Person();
        person.setAvatarIndex(3);

        assertEquals(3, person.getAvatarIndex());
    }

    @Test
    void avatarIndexBelowOneMeansNoCharacter() {
        Person person = new Person();
        person.setAvatarIndex(0);
        assertNull(person.getAvatarIndex());

        person.setAvatarIndex(-4);
        assertNull(person.getAvatarIndex());

        person.setAvatarIndex(null);
        assertNull(person.getAvatarIndex());
    }

    @Test
    void noteIsTrimmedAndBlankMeansNoNote() {
        Person person = new Person();
        person.setNote("  Vegetariana  ");
        assertEquals("Vegetariana", person.getNote());

        person.setNote("   ");
        assertNull(person.getNote());

        person.setNote(null);
        assertNull(person.getNote());
    }

    @Test
    void noteLongerThanTheColumnIsCut() {
        Person person = new Person();
        person.setNote("a".repeat(Person.NOTE_MAX_LENGTH + 50));

        assertEquals(Person.NOTE_MAX_LENGTH, person.getNote().length());
    }
}
