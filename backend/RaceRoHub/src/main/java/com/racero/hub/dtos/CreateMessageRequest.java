package com.racero.hub.dtos;

import lombok.Data;

@Data
public class CreateMessageRequest {
    private Long receiverId;
    private String content;
}
