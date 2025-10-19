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
public class Track {
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Id
    public Long id;

    public String location;
    public String distance;
    public String description;
    public String imageUrl;

}
