package com.example.autotrader.core.data;

import java.util.Objects;
import java.util.function.Function;

/**
 * Represents the left side of an Either (usually a failure).
 */
public final class Left<L, R> implements Either<L, R> {

    private final L value;

    public Left(L value) {
        this.value = value;
    }

    public L getValue() {
        return value;
    }

    @Override
    public <B> B fold(Function<? super L, ? extends B> ifLeft,
                      Function<? super R, ? extends B> ifRight) {
        return ifLeft.apply(value);
    }

    @Override
    public boolean equals(Object o) {
        return o instanceof Left<?, ?> other && Objects.equals(value, other.value);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(value);
    }

    @Override
    public String toString() {
        return "Left(" + value + ")";
    }
}