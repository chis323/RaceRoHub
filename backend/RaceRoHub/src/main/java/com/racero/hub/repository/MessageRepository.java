package com.racero.hub.repository;

import com.racero.hub.model.Message;
import com.racero.hub.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query("""
           SELECT m FROM Message m
           WHERE (m.sender = :u1 AND m.receiver = :u2)
              OR (m.sender = :u2 AND m.receiver = :u1)
           ORDER BY m.createdAt ASC
           """)
    List<Message> findConversation(User u1, User u2);
}
