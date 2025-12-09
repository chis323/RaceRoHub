package com.racero.hub.controller;

import com.racero.hub.dtos.CreateMessageRequest;
import com.racero.hub.dtos.MessageDto;
import com.racero.hub.service.MessageService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    private final MessageService messageService;
    private final HttpServletRequest request;

    public MessageController(MessageService messageService,
                             HttpServletRequest request) {
        this.messageService = messageService;
        this.request = request;
    }

    private Long getCurrentUserId() {
        String header = request.getHeader("X-User-Id");
        if (header == null || header.isBlank()) {
            return 102L; // dev fallback
        }
        try {
            return Long.parseLong(header);
        } catch (NumberFormatException ex) {
            return 102L;
        }
    }

    @PostMapping
    public MessageDto sendMessage(@RequestBody CreateMessageRequest req) {
        return messageService.sendMessage(getCurrentUserId(), req);
    }

    @GetMapping("/with/{partnerId}")
    public List<MessageDto> getConversation(@PathVariable Long partnerId) {
        return messageService.getConversation(getCurrentUserId(), partnerId);
    }

    @GetMapping
    public List<MessageDto> getAllMessages() {
        return messageService.getAllMessages();
    }

    @DeleteMapping("/all")
    public void deleteAllMessages() {
        messageService.deleteAllMessages();
    }
}
