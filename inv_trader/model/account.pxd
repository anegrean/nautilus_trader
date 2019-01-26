#!/usr/bin/env python3
# -------------------------------------------------------------------------------------------------
# <copyright file="account.pxd" company="Invariance Pte">
#  Copyright (C) 2018-2019 Invariance Pte. All rights reserved.
#  The use of this source code is governed by the license as found in the LICENSE.md file.
#  http://www.invariance.com
# </copyright>
# -------------------------------------------------------------------------------------------------

# cython: language_level=3, boundscheck=False, wraparound=False, nonecheck=False

from cpython.datetime cimport datetime

from inv_trader.enums.brokerage cimport Broker
from inv_trader.enums.currency_code cimport CurrencyCode
from inv_trader.model.events cimport AccountEvent
from inv_trader.model.identifiers cimport AccountId, AccountNumber



cdef class Account:
    """
    Represents a brokerage account.
    """
    cdef list _events

    cdef readonly bint initialized
    cdef readonly AccountId id
    cdef readonly Broker broker
    cdef readonly AccountNumber account_number
    cdef readonly CurrencyCode currency
    cdef readonly free_equity
    cdef readonly cash_balance
    cdef readonly cash_start_day
    cdef readonly cash_activity_day
    cdef readonly margin_used_liquidation
    cdef readonly margin_used_maintenance
    cdef readonly margin_ratio
    cdef readonly str margin_call_status
    cdef readonly datetime last_updated
    cdef readonly int event_count
    cdef readonly AccountEvent last_event

    cpdef list get_events(self)
    cpdef void apply(self, AccountEvent event)
    cdef void _initialize(self, AccountEvent event)
