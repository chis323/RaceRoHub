package com.racero.hub.service;

import com.racero.hub.model.Track;
import com.racero.hub.repository.TrackRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TrackService {
    private final TrackRepository trackRepository;

    public TrackService(TrackRepository trackRepository) {
        this.trackRepository = trackRepository;
    }

    public List<Track> findAll() {
        return trackRepository.findAll();
    }

}
