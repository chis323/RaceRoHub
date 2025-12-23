package com.racero.hub.service;

import com.racero.hub.dtos.PostDto;
import com.racero.hub.model.Post;
import com.racero.hub.model.User;
import com.racero.hub.repository.PostRepository;
import com.racero.hub.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Service
public class PostService {

    private final PostRepository postRepository;
    private final UserRepository userRepository;
    private final Path uploadDir;

    public PostService(
            PostRepository postRepository,
            UserRepository userRepository,
            @Value("${app.upload-dir}") String uploadDir
    ) {
        this.postRepository = postRepository;
        this.userRepository = userRepository;
        this.uploadDir = Path.of(uploadDir).toAbsolutePath().normalize();
    }

    public Post createPost(PostDto request, MultipartFile imageFile) throws IOException {
        User author = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + request.getUserId()));

        if(!Objects.equals(author.getRole(), "admin"))
            throw new IllegalArgumentException("You do not have permission to add this post");

        String filename = null;
        if (imageFile != null && !imageFile.isEmpty()) {
            filename = storeImage(imageFile);
        }

        Post post = new Post();
        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        post.setImage(filename);
        post.setDate(LocalDateTime.now());
        post.setAuthor(author);

        return postRepository.save(post);
    }

    public List<Post> getAllPosts() {
        return postRepository.findAll();
    }

    private String storeImage(MultipartFile file) throws IOException {
        Files.createDirectories(uploadDir);

        String original = StringUtils.cleanPath(file.getOriginalFilename() == null ? "image" : file.getOriginalFilename());
        String ext = "";

        int dot = original.lastIndexOf('.');
        if (dot >= 0) ext = original.substring(dot).toLowerCase();

        if (!ext.matches("\\.(png|jpg|jpeg|webp|gif)")) {
            throw new IllegalArgumentException("Unsupported file type: " + ext);
        }

        String filename = UUID.randomUUID() + ext;
        Path target = uploadDir.resolve(filename).normalize();

        if (!target.startsWith(uploadDir)) {
            throw new IllegalArgumentException("Invalid path");
        }

        Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
        return filename;
    }
}
