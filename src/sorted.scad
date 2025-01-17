/**
 * @file sorted.scad
 * @brief Implementation of a general-purpose sorting function for OpenSCAD.
 *
 * This library provides a versatile `sorted` function that can sort lists using
 * optional comparison or key functions, and supports reversing the sort order.
 * It utilizes a recursive quicksort algorithm implemented through helper functions.
 *
 * @copyright Justin Lin, 2022
 * @license https://opensource.org/licenses/lgpl-3.0.html
 *
 * @see https://openhome.cc/eGossip/OpenSCAD/lib3x-sorted.html
 *
 * Modified by Cameron K. Brooks for formatting and documentation purposes only.
 *
 */

/**
 * @brief Sorts a list using an optional comparison function or key function.
 *
 * This is a general-purpose sorting function that can sort a list `lt` based on a comparison function `cmp`,
 * a key function `key`, and an optional reverse flag. It leverages helper functions to implement a quicksort algorithm.
 *
 * @param lt The list to be sorted.
 * @param cmp (Optional) A comparison function that takes two arguments and returns -1, 0, or 1.
 * @param key (Optional) A function that extracts a comparison key from each list element.
 * @param reverse (Optional) If true, the list elements are sorted in descending order.
 * @return A sorted list.
 */
function sorted(lt, cmp = undef, key = undef, reverse = false) = let(is_cmp_undef = is_undef(cmp)) is_cmp_undef &&
                                                                         is_undef(key)
                                                                     ? _sorted_default(lt, reverse)
                                                                 : is_cmp_undef ? _sorted_key(lt, key, reverse)
                                                                                : _sorted_cmp(lt, cmp, reverse);

// Helper functions from _sorted_impl.scad

/**
 * @brief Partitions the list into elements before and after the pivot based on the comparison function.
 *
 * This recursive function is a core part of the quicksort algorithm. It divides the list `lt` into two lists:
 * `before` contains elements less than the pivot, and `after` contains elements greater than or equal to the pivot.
 *
 * @param lt The list being partitioned.
 * @param pivot The pivot element for partitioning.
 * @param less The comparison function to determine ordering.
 * @param leng The length of the list `lt`.
 * @param before (Optional) Accumulator list for elements less than the pivot.
 * @param after (Optional) Accumulator list for elements greater than or equal to the pivot.
 * @param j (Optional) The current index in the list `lt`, starting from 1.
 * @return A tuple [before, after], where `before` is a list of elements less than the pivot, and `after` is the rest.
 */
function before_after(lt, pivot, less, leng, before = [], after = [],
                      j = 1) = j == leng
                                   ? [ before, after ]
                                   : let(is_less = less(lt[j], pivot))
                                         before_after(lt, pivot, less, leng, is_less ? [ each before, lt[j] ] : before,
                                                      is_less ? after : [ each after, lt[j] ], j + 1);

/**
 * @brief Identity function that returns the element as is.
 *
 * Used as a default function when no key extraction is needed.
 *
 * @param elem The element to be returned.
 * @return The same element `elem`.
 */
identity = function(elem) elem;

/**
 * @brief Applies a function to each element in a list.
 *
 * @param lt The list of elements.
 * @param elem A function to apply to each element.
 * @return A new list with the function `elem` applied to each element.
 */
function elems(lt, elem) = [for (e = lt) elem(e)];

/**
 * @brief Recursive quicksort algorithm to sort a list based on a comparison function.
 *
 * This function implements the quicksort algorithm by selecting a pivot and partitioning the list into sublists.
 *
 * @param lt The list to be sorted.
 * @param less A comparison function that returns true if the first argument is less than the second.
 * @param elem (Optional) A function to apply to each element before returning; defaults to the identity function.
 * @return A sorted list.
 */
function _sorted(lt, less, elem = identity) =
    let(leng = len(lt)) leng <= 1 ? elems(lt, elem)
    : leng == 2
        ? less(lt[0], lt[1]) ? elems(lt, elem) : [ elem(lt[1]), elem(lt[0]) ]
        : let(pivot = lt[0], b_a = before_after(lt, pivot, less, leng))[each _sorted(b_a[0], less, elem), elem(pivot),
                                                                        each _sorted(b_a[1], less, elem)];

/**
 * @brief Default sorting function using natural order.
 *
 * Sorts the list `lt` in ascending or descending order based on the `reverse` flag.
 *
 * @param lt The list to be sorted.
 * @param reverse If true, sorts the list in descending order.
 * @return A sorted list.
 */
function _sorted_default(lt, reverse) = _sorted(lt, reverse ? function(a, b) a > b : function(a, b) a < b);

/**
 * @brief Sorting function using a custom comparison function.
 *
 * Sorts the list `lt` based on the provided comparison function `cmp`.
 *
 * @param lt The list to be sorted.
 * @param cmp A comparison function that takes two arguments and returns -1, 0, or 1.
 * @param reverse If true, reverses the sorting order.
 * @return A sorted list.
 */
function _sorted_cmp(lt, cmp, reverse) = _sorted(lt,
                                                 reverse ? function(a, b) cmp(a, b) > 0 : function(a, b) cmp(a, b) < 0);

/**
 * @brief Sorting function using a key extraction function.
 *
 * Sorts the list `lt` by applying the `key` function to each element and comparing the keys.
 *
 * @param lt The list to be sorted.
 * @param key A function that extracts a comparison key from each list element.
 * @param reverse If true, sorts the list in descending order based on the keys.
 * @return A sorted list.
 */
function _sorted_key(lt, key, reverse) = let(key_elem_lt = [for (elem = lt)[key(elem), elem]])
    _sorted(key_elem_lt, reverse ? function(a, b) a[0] > b[0] : function(a, b) a[0] < b[0], function(elem) elem[1]);