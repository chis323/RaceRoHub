package com.racero.hub.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "app_user")
public class User {
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Id
    public Long id;

    public String name;
    public String password;
    public String role = "user";

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JoinColumn(name = "car_id")
    public Car car;
}
