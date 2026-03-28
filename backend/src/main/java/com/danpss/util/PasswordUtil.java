package com.danpss.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public final class PasswordUtil {
    private PasswordUtil() {
    }

    public static String hashPassword(String password) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
        StringBuilder builder = new StringBuilder(hash.length * 2);
        for (int i = 0; i < hash.length; i++) {
            builder.append(String.format("%02x", Integer.valueOf(hash[i] & 0xff)));
        }
        return builder.toString();
    }

    public static boolean verifyPassword(String rawPassword, String storedPassword) throws Exception {
        if (rawPassword == null || storedPassword == null) {
            return false;
        }
        String normalizedStored = storedPassword.trim();
        if (normalizedStored.length() == 64 && normalizedStored.matches("[0-9a-fA-F]{64}")) {
            return hashPassword(rawPassword).equalsIgnoreCase(normalizedStored);
        }
        return rawPassword.equals(storedPassword);
    }
}
