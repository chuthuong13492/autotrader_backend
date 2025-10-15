package com.example.autotrader.core.data;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.function.Function;
import java.util.function.Predicate;

/**
 * Generic Pagination wrapper for API responses
 * 
 * Inspired by Flutter/Dart pagination pattern but adapted for Java/Spring Boot
 * 
 * @param <T> Type of items in the pagination
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Pagination<T> {
    
    /**
     * Pagination items
     */
    @JsonProperty("list")
    private List<T> list;
    
    /**
     * Current page (1-based)
     */
    @JsonProperty("page")
    private int page;
    
    /**
     * Number of items per page
     */
    @JsonProperty("pageSize")
    private int pageSize;
    
    /**
     * Total number of pages
     */
    @JsonProperty("pageCount")
    private int pageCount;
    
    /**
     * Total number of items
     */
    @JsonProperty("total")
    private long total;
    
    /**
     * Error during data loading if any
     */
    @JsonProperty("error")
    private String error;
    
    /**
     * Create an empty pagination
     */
    public static <T> Pagination<T> empty() {
        return Pagination.<T>builder()
                .list(List.of())
                .page(0)
                .pageSize(0)
                .pageCount(0)
                .total(0L)
                .build();
    }
    
    /**
     * Create pagination with data (page is 1-based)
     */
    public static <T> Pagination<T> of(List<T> list, int page, int pageSize, long total) {
        int pageCount = (int) Math.ceil((double) total / pageSize);
        return Pagination.<T>builder()
                .list(list)
                .page(page)  // page is already 1-based from Spring Data
                .pageSize(pageSize)
                .pageCount(pageCount)
                .total(total)
                .build();
    }
    
    /**
     * Whether the current page is the last page
     */
    @JsonProperty("last")
    public boolean isLast() {
        return page >= pageCount;
    }
    
    /**
     * Whether there is a next page
     */
    @JsonProperty("hasNext")
    public boolean hasNext() {
        return !isLast();
    }
    
    /**
     * Whether there is a previous page
     */
    @JsonProperty("hasPrevious")
    public boolean hasPrevious() {
        return page > 1;
    }
    
    /**
     * Copy the pagination with new values
     */
    public Pagination<T> copyWith(List<T> newList, Integer newPage, Integer newPageSize, Long newTotal) {
        return Pagination.<T>builder()
                .list(newList != null ? newList : this.list)
                .page(newPage != null ? newPage : this.page)
                .pageSize(newPageSize != null ? newPageSize : this.pageSize)
                .total(newTotal != null ? newTotal : this.total)
                .error(this.error)
                .build();
    }
    
    /**
     * Transform the list items using a mapper function
     */
    public <R> Pagination<R> map(Function<T, R> mapper) {
        List<R> mappedList = list.stream()
                .map(mapper)
                .toList();
        
        return Pagination.<R>builder()
                .list(mappedList)
                .page(this.page)
                .pageSize(this.pageSize)
                .pageCount(this.pageCount)
                .total(this.total)
                .error(this.error)
                .build();
    }
    
    /**
     * Filter the list items using a predicate
     */
    public Pagination<T> filter(Predicate<T> predicate) {
        List<T> filteredList = list.stream()
                .filter(predicate)
                .toList();
        
        return Pagination.<T>builder()
                .list(filteredList)
                .page(this.page)
                .pageSize(this.pageSize)
                .pageCount(this.pageCount)
                .total(this.total)
                .error(this.error)
                .build();
    }
    
    @Override
    public String toString() {
        return String.format("Pagination{list: %s, page: %d, pageSize: %d, pageCount: %d, total: %d}", 
                list != null ? list.size() + " items" : "null", 
                page, pageSize, pageCount, total);
    }
}
