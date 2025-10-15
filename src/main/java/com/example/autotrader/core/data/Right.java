package com.example.autotrader.core.data;

import java.util.Objects;
import java.util.function.Function;

/**
 * Represents the right side of an Either (usually a success).
 */
public final class Right<L, R> implements Either<L, R> {

    private final R value;

    public Right(R value) {
        this.value = value;
    }

    public R getValue() {
        return value;
    }

    @Override
    public <B> B fold(Function<? super L, ? extends B> ifLeft,
                      Function<? super R, ? extends B> ifRight) {
        return ifRight.apply(value);
    }

    @Override
    public boolean equals(Object o) {
        return o instanceof Right<?, ?> other && Objects.equals(value, other.value);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(value);
    }

    @Override
    public String toString() {
        return "Right(" + value + ")";
    }
}