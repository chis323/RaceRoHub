package com.racero.hub.dtos;

import lombok.Data;

@Data
public class MessageDto {
    private Long id;
    private Long senderId;
    private Long receiverId;
    private String content;
    private String createdAt;
    private String readAt;
}
