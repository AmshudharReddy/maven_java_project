package com.example;


import org.junit.jupiter.api.Test;


import static org.junit.jupiter.api.Assertions.*;


public class AppTest {


@Test
public void testAddPositive() {
assertEquals(5, App.add(2, 3));
}


@Test
public void testAddNegative() {
assertEquals(-1, App.add(2, -3));
}
}