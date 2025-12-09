package com.racero.hub.service;

import com.racero.hub.dtos.CreateMessageRequest;
import com.racero.hub.dtos.MessageDto;
import com.racero.hub.model.Message;
import com.racero.hub.model.User;
import com.racero.hub.repository.MessageRepository;
import com.racero.hub.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MessageService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    public MessageService(MessageRepository messageRepository,
                          UserRepository userRepository) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
    }

    public MessageDto sendMessage(Long senderId, CreateMessageRequest req) {
        User sender = userRepository.findById(senderId).orElseThrow();
        User receiver = userRepository.findById(req.getReceiverId()).orElseThrow();

        Message m = new Message();
        m.setSender(sender);
        m.setReceiver(receiver);
        m.setContent(req.getContent());

        m = messageRepository.save(m);

        return toDto(m);
    }

    public void deleteAllMessages() {
        messageRepository.deleteAll();
    }


    public List<MessageDto> getConversation(Long userId, Long partnerId) {
        User u1 = userRepository.findById(userId).orElseThrow();
        User u2 = userRepository.findById(partnerId).orElseThrow();

        return messageRepository.findConversation(u1, u2)
                .stream()
                .map(this::toDto)
                .toList();
    }

    public void deleteById(Long id) {
        messageRepository.deleteById(id);
    }

    public List<MessageDto> getAllMessages() {
        return messageRepository.findAll()
                .stream()
                .map(this::toDto)
                .toList();
    }



    private MessageDto toDto(Message m) {
        MessageDto dto = new MessageDto();
        dto.setId(m.getId());
        dto.setSenderId(m.getSender().getId());
        dto.setReceiverId(m.getReceiver().getId());
        dto.setContent(m.getContent());
        dto.setCreatedAt(m.getCreatedAt().toString());
        dto.setReadAt(m.getReadAt() == null ? null : m.getReadAt().toString());
        return dto;
    }
}
