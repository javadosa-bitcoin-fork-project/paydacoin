// Copyright (c) 2011-2020 The Paydacoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef PAYDACOIN_QT_PAYDACOINADDRESSVALIDATOR_H
#define PAYDACOIN_QT_PAYDACOINADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class PaydacoinAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit PaydacoinAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

/** Paydacoin address widget validator, checks for a valid paydacoin address.
 */
class PaydacoinAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit PaydacoinAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

#endif // PAYDACOIN_QT_PAYDACOINADDRESSVALIDATOR_H
