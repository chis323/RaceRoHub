package com.racero.hub.controller;

import com.racero.hub.dtos.UserDto;
import com.racero.hub.model.User;
import com.racero.hub.service.UserService;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*") // tighten to your frontend origin later
public class UserController {
    private final UserService svc;

    public UserController(UserService svc) { this.svc = svc; }

    @GetMapping("/{id}")
    public User get(@PathVariable Long id) { return svc.get(id); }

    @PostMapping
    public User create(@RequestBody UserDto u) { return svc.create(u); }

    @PatchMapping("/{id}")
    public User patch(@PathVariable Long id, @RequestBody Map<String, Object> patch) {
        return svc.update(id, patch);
    }

    @PostMapping("/auth/login")
    public User login(@RequestBody UserDto u) {
        return svc.login(u);
    }
}
