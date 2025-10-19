package com.racero.hub.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class Car {
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Id
    public Long id;

    public String model;
    public String engine;
    public String suspensions;
    public String gearbox;
    public String brakes;
    public String wheels;
    public String aero;
}
