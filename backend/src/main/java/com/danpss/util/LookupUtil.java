package com.danpss.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public final class LookupUtil {
    private LookupUtil() {
    }

    public static int requireIdByName(Connection con, String table, String idColumn, String nameColumn, String value) throws Exception {
        Integer id = findIdByName(con, table, idColumn, nameColumn, value);
        if (id == null) {
            throw new IllegalStateException("Missing lookup value '" + value + "' in table " + table);
        }
        return id.intValue();
    }

    public static int findOrCreateByName(Connection con, String table, String idColumn, String nameColumn, String value) throws Exception {
        Integer existing = findIdByName(con, table, idColumn, nameColumn, value);
        if (existing != null) {
            return existing.intValue();
        }

        String insert = "INSERT INTO " + table + " (" + nameColumn + ") VALUES (?)";
        try (PreparedStatement ps = con.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, value.trim());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return requireIdByName(con, table, idColumn, nameColumn, value);
    }

    public static Integer findIdByName(Connection con, String table, String idColumn, String nameColumn, String value) throws Exception {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT " + idColumn + " FROM " + table + " WHERE " + nameColumn + " = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, value.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Integer.valueOf(rs.getInt(1));
                }
                return null;
            }
        }
    }
}
