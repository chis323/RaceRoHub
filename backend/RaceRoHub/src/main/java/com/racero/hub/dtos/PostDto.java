package com.racero.hub.dtos;

import lombok.Data;

@Data
public class PostDto {
    private String title;
    private String content;
    private Long userId;
}

