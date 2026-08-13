---
id: PRD-904
title: Checkout abandonment
status: draft
date: 2026-08-13
---

# PRD-904: Checkout abandonment

## Problem

Customers who have put items in the basket leave before they have paid, and the
team cannot tell whether that is a problem with the payment step or with the
shipping costs that are shown at the end. The data we have does not separate
those two, so every proposal about the checkout is an argument about which of
them matters more.

## Outcome

We want to know, for each abandoned basket, which step it was abandoned at and
what the customer had seen by then, so that the next change to the checkout is
made against evidence and not against a guess.

## Scope

This covers the events and the report that reads them. It does not cover any
change to the payment provider, and it does not cover the basket itself.

## Why now

The team is about to rebuild the shipping estimate, and without this they will
not be able to tell whether that rebuild helped or hurt.
