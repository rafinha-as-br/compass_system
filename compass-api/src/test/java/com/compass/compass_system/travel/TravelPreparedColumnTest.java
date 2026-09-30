package com.compass.compass_system.travel;

import jakarta.persistence.Column;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;

import static org.assertj.core.api.Assertions.assertThat;

// CPS-166: sem um DEFAULT explicito no DDL, Hibernate (ddl-auto=update) emite
// "ALTER TABLE ... NOT NULL" puro, que o Postgres rejeita contra uma tabela
// que ja tem linhas (CPS-TC-95). @DataJpaTest não pega essa regressão porque
// recria o schema do zero a cada teste; este teste trava a anotação em si.
class TravelPreparedColumnTest {

    @Test
    void preparedColumnDeclaresDefaultForIncrementalMigration() throws NoSuchFieldException {
        Field field = Travel.class.getDeclaredField("prepared");
        Column column = field.getAnnotation(Column.class);

        assertThat(column).isNotNull();
        assertThat(column.columnDefinition().toLowerCase()).contains("default");
    }
}
