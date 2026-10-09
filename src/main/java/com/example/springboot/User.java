package com.example.springboot;

@Override
public String toString() {
    return "User{id=" + id + ", name='" + name + "'}";
}


public class User {
    private Long id;
    private String name;
    public User(Long id, String name) {
        this.id = id;
        this.name = name;
    }
}
