package com.racero.hub.service;

import com.racero.hub.dtos.CarDto;
import com.racero.hub.model.Car;
import com.racero.hub.model.User;
import com.racero.hub.repository.CarRepository;
import com.racero.hub.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CarService {

    private final CarRepository carRepository;
    private final UserRepository userRepository;

    @Transactional
    public CarDto createOrReplaceCarForUser(Long userId, CarDto dto) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found with id " + userId));

        Car car = user.getCar();
        if (car == null) {
            car = new Car();
        }

        car.setModel(dto.getModel());
        car.setEngine(dto.getEngine());
        car.setSuspensions(dto.getSuspensions());
        car.setGearbox(dto.getGearbox());
        car.setBrakes(dto.getBrakes());
        car.setWheels(dto.getWheels());
        car.setAero(dto.getAero());

        Car saved = carRepository.save(car);

        user.setCar(saved);
        userRepository.save(user);

        return mapToDto(saved);
    }

    @Transactional(readOnly = true)
    public CarDto getCarForUser(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found with id " + userId));

        Car car = user.getCar();
        if (car == null) {
            throw new RuntimeException("User with id " + userId + " has no car");
        }

        return mapToDto(car);
    }

    @Transactional
    public CarDto patchCarForUser(Long userId, CarDto dto) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found with id " + userId));

        Car car = user.getCar();
        if (car == null) {
            throw new RuntimeException("User with id " + userId + " has no car to patch");
        }

        // patch only non-null fields
        if (dto.getModel() != null) car.setModel(dto.getModel());
        if (dto.getEngine() != null) car.setEngine(dto.getEngine());
        if (dto.getSuspensions() != null) car.setSuspensions(dto.getSuspensions());
        if (dto.getGearbox() != null) car.setGearbox(dto.getGearbox());
        if (dto.getBrakes() != null) car.setBrakes(dto.getBrakes());
        if (dto.getWheels() != null) car.setWheels(dto.getWheels());
        if (dto.getAero() != null) car.setAero(dto.getAero());

        Car saved = carRepository.save(car);
        return mapToDto(saved);
    }

    private CarDto mapToDto(Car car) {
        CarDto dto = new CarDto();
        dto.setId(car.getId());
        dto.setModel(car.getModel());
        dto.setEngine(car.getEngine());
        dto.setSuspensions(car.getSuspensions());
        dto.setGearbox(car.getGearbox());
        dto.setBrakes(car.getBrakes());
        dto.setWheels(car.getWheels());
        dto.setAero(car.getAero());
        return dto;
    }
}
