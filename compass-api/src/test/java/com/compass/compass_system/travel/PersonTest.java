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
}
