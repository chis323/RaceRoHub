package com.racero.hub.controller;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.racero.hub.dtos.PostDto;
import com.racero.hub.model.Post;
import com.racero.hub.service.PostService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/posts")
public class PostController {

    private final PostService postService;

    public PostController(PostService postService) {
        this.postService = postService;
    }

    @GetMapping
    public ResponseEntity<List<Post>> getAll() {
        return ResponseEntity.ok(postService.getAllPosts());
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Post> create(
            @RequestPart("post") String request,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) throws IOException {
        PostDto postDto = new ObjectMapper().readValue(request, PostDto.class);
        return ResponseEntity.ok(postService.createPost(postDto, image));
    }
}