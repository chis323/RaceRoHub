package com.racero.hub.dtos;

import lombok.Data;

@Data
public class CarDto {
    private Long id;
    private String model;
    private String engine;
    private String suspensions;
    private String gearbox;
    private String brakes;
    private String wheels;
    private String aero;
}
