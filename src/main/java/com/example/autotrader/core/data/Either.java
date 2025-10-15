package com.example.autotrader.core.data;

import java.util.function.Function;

/**
 * Represents a value of one of two possible types (a disjoint union).
 * Instances of Either are either an instance of Left or Right.
 * By convention, Left is used for failure and Right for success.
 */
public interface Either<L, R> {

    <B> B fold(Function<? super L, ? extends B> ifLeft,
               Function<? super R, ? extends B> ifRight);

    default boolean isLeft() {
        return fold(l -> true, r -> false);
    }

    default boolean isRight() {
        return fold(l -> false, r -> true);
    }

    default L leftOrNull() {
        return fold(l -> l, r -> null);
    }

    default R rightOrNull() {
        return fold(l -> null, r -> r);
    }

    default <B> B foldLeft(Function<? super L, ? extends B> ifLeft) {
        return fold(ifLeft, r -> null);
    }

    default <B> B foldRight(Function<? super R, ? extends B> ifRight) {
        return fold(l -> null, ifRight);
    }

    static <L, R> Either<L, R> left(L value) {
        return new Left<>(value);
    }

    static <L, R> Either<L, R> right(R value) {
        return new Right<>(value);
    }
}