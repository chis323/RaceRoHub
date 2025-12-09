package com.racero.hub.service;

import com.racero.hub.dtos.UserDto;
import com.racero.hub.exceptions.UnauthorizedException;
import com.racero.hub.model.User;
import com.racero.hub.repository.UserRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.lang.reflect.Field;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;

@Service
public class UserService {
    private final UserRepository repo;

    public UserService(UserRepository repo) {
        this.repo = repo;
    }

    public User get(Long id) {
        return repo.findById(id)
                .orElseThrow(() -> new NoSuchElementException("User not found"));
    }

    // --------- create: return 409 when username already exists ----------
    public User create(UserDto u) {
        try {
            // proactive check -> clean 409 for the client
            if (repo.existsByName(u.getName())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already exists");
            }

            User user = new User();
            user.setName(u.getName());
            user.setPassword(u.getPassword()); // NOTE: store hashes in real apps
            user.setCar(null);
            return repo.save(user);
        } catch (DataIntegrityViolationException dive) {
            // safety net in case two requests race or DB uniqueness triggers first
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already exists");
        }
    }

    public User update(Long id, Map<String, Object> patch) {
        User u = get(id);
        applyPatch(u, patch, Set.of("id", "password", "createdAt"));
        return repo.save(u);
    }

    private void applyPatch(Object target, Map<String, Object> patch, Set<String> disallow) {
        if (patch == null) return;
        for (var e : patch.entrySet()) {
            String key = e.getKey();
            if (disallow.contains(key)) continue;
            trySetField(target, key, e.getValue());
        }
    }

    private void trySetField(Object target, String fieldName, Object value) {
        try {
            Field f = findField(target.getClass(), fieldName);
            if (f == null) return;
            f.setAccessible(true);
            Object cast = castValue(f.getType(), value);
            f.set(target, cast);
        } catch (Exception ignored) {}
    }

    private Field findField(Class<?> type, String name) {
        Class<?> t = type;
        while (t != null && t != Object.class) {
            try {
                return t.getDeclaredField(name);
            } catch (NoSuchFieldException ex) {
                t = t.getSuperclass();
            }
        }
        return null;
    }

    private Object castValue(Class<?> to, Object v) {
        if (v == null) return null;
        if (to.isInstance(v)) return v;
        if (to == Integer.class || to == int.class) return Integer.parseInt(v.toString());
        if (to == Long.class || to == long.class) return Long.parseLong(v.toString());
        if (to == Double.class || to == double.class) return Double.parseDouble(v.toString());
        if (to == Boolean.class || to == boolean.class) return Boolean.parseBoolean(v.toString());
        if (to == String.class) return v.toString();
        return v;
    }

    // login: 401 for any wrong combo (user missing OR bad password)
    public User login(UserDto dto) {
        return repo.findByNameAndPassword(dto.getName(), dto.getPassword())
                .orElseThrow(() -> new UnauthorizedException("Invalid credentials"));
    }

    // 🔍 NEW: search users by (partial) name, case-insensitive
    public List<User> searchByName(String query) {
        if (query == null || query.isBlank()) {
            return List.of();
        }
        return repo.findByNameContainingIgnoreCase(query.trim());
    }
}
