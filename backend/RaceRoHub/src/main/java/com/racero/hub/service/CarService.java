package com.racero.hub.service;

import com.racero.hub.model.Car;
import com.racero.hub.repository.CarRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.NoSuchElementException;
import java.util.Optional;

@Service
@AllArgsConstructor
public class CarService {
    private final CarRepository carRepo;

    public Car getCarById(Long id) {
        return carRepo.findById(id).orElseThrow(() -> new NoSuchElementException("Car not found"));
    }
}
