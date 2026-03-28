package com.danpss.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DBUtil {
    private static String url;
    private static String user;
    private static String password;

    static {
        try (InputStream in = DBUtil.class.getResourceAsStream("/db.properties")){
            if (in == null) {
                throw new IllegalStateException("db.properties was not found on the application classpath.");
            }
            Properties p = new Properties();
            p.load(in);
            url = firstNonBlank(System.getenv("DANPSS_DB_URL"), p.getProperty("db.url"));
            user = firstNonBlank(System.getenv("DANPSS_DB_USER"), p.getProperty("db.user"));
            password = firstNonBlank(System.getenv("DANPSS_DB_PASSWORD"), p.getProperty("db.password"));

            if (isBlank(url) || isBlank(user)) {
                throw new IllegalStateException("Database configuration is incomplete. Check db.properties.");
            }
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static Connection getConnection() throws Exception{
        return DriverManager.getConnection(url, user, password);
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private static String firstNonBlank(String preferred, String fallback) {
        return isBlank(preferred) ? fallback : preferred.trim();
    }
}
