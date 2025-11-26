package com.racero.hub.controller;
import com.racero.hub.dtos.CarDto;
import com.racero.hub.service.CarService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/car/{userId}")
@AllArgsConstructor
public class CarController {

    private final CarService carService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CarDto createOrReplaceCar(
            @PathVariable Long userId,
            @RequestBody CarDto carDto
    ) {
        return carService.createOrReplaceCarForUser(userId, carDto);
    }

    @GetMapping
    public CarDto getCar(@PathVariable Long userId) {
        return carService.getCarForUser(userId);
    }

    @PatchMapping
    public CarDto patchCar(
            @PathVariable Long userId,
            @RequestBody CarDto carDto
    ) {
        return carService.patchCarForUser(userId, carDto);
    }
}
