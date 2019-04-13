/*
 * This file is part of the Skycoin project, https://skycoin.net/
 *
 * Copyright (C) 2018-2019 Skycoin Project
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

char TEST_MANY_ADDRESSES[100][36] = {
  "2Niqzo12tZ9ioZq5vwPHMVR4g7UVpp9TCmP",
  "2UDzBKnxZf4d9pdrBJAqbtoeH641RFLYKxd",
  "8LbGZ9Z9r7ELNKyrQmAbhLhLvrmLJjfotm",
  "7KU683yzoPE9rVuuFRQMZVhGwBBtwqTKT2",
  "gwgdez9f3BLvQyNE5tMFS75p69zs2i3mRq",
  "aSEqXrooiycfyXDc2aLYLGSmjrozJh3jCn",
  "2Z6WpR2RoBBF722hZ75ShDp1LVmojSRfAiF",
  "25sH1HLTQbr1CR4uxkMFtJY2WLLwFVPqzKQ",
  "MGiD4Bg65F7bQhaKmhCLsaVKKeEFLuGgA3",
  "2bYFuBzZ7QiEbpJophC2pFhQLbEFt3YSSJH",
  "yExu4fryscnahAEMKa7XV4Wc1mY188KvGw",
  "23GxEvPcy5vFPuzuP8o3PBag3HgQdoaWyXb",
  "2C3JbrfoE4dSjZ5dE4hxrYCmmmrcFEGyiUL",
  "KE9oA24AuPzDzWBEjhGJu7PHZsQjGXYcww",
  "2KnZdRBrVkK7EyzPxFdYrAoZ17MwjxxaCR",
  "2NGNQTdVNxZQPpBvj64ecidwXF3ZhhkX922",
  "3sNLvvtb5wFLMhoFxhSb9FiySLGoAzNbGd",
  "2kaTspbcfCyWNatPbRNZ55Xg8zyp77rNgv7",
  "2mcYBt3gpiYFjkTZQHP142R3NF4JZimhSzk",
  "d4vFNveNynBj56XWK4M5cHw5JGLdc9arDb",
  "trJzid787SDzbZke8HGGabsRJxf5UYQ24t",
  "843rtbppb1fS7GLipW2VdAJ6U3ASNYEYXS",
  "Jn8SM7bRtzC49hb5ndj8RSjbqUUUPqMj3A",
  "2BwTfjCK38ucP4UAdAX1HbzR7etZcBY6FXr",
  "2XRhzqNgRJgT6rNp1FVp2SyZfrDedjSKUWx",
  "o8xuJ8PVfeBCSsZkR5hoB12ooBwXJzVztB",
  "S49fz7SUwStZvhTM7DuJfN2DKPgkb9bo5r",
  "FZRetm6mneEEkXzZTGhMfWvK4yaSo1rjf4",
  "pC4nG37Nz9VWTfEXJjgSP7wKDRzNkF4bn2",
  "uVfk3t6iE5f37MVCDKrquUewt2KJWZJNTP",
  "25sESDqRTSKZbq1Z7UUykw1UxnxejaeHKNV",
  "agYZZqeEPpHYS2Ks9tmtbBEg6xTCYZVatb",
  "2TpoqeGL2tHKnfBzaBpD6oo3E37rA5X74bA",
  "22y8iKcVhL9337QPXWAM5m68f9eKHcjhU44",
  "f1YscDhp9YWMEnYbPtdJE4F7yaV7GsNTPS",
  "nHPDziRL3wwDpe9rGsTUEocAQbyRHAJigC",
  "bx6Z6THQsmto8ANcgNb9WGhpedQWhvKiPD",
  "2NAfLeTNC19wof25NSBNpKGTtKt1iEZtxDT",
  "9L2uQrmvmgeQDYSgiPAmczWAgJTWekBG6X",
  "8pDsA7hNgcGmugiq9SqbpBAr8LNvqXhYCd",
  "HDVGBNTJmnVeU1wY4iEiDmT4KoNoJ97DVk",
  "28GUdCt1ACa7Rn8pN9ekxugDh1hWgiY8W5m",
  "zW4yhXcYE1ehseDfsCyRJCfsT9aFJ1P7j9",
  "8oEmZLjUnFx8DCt6Jpbyz7iNDEfgg5FwXG",
  "2FxepT5DXPGNW647tuCakM4HxzLPKXA5mnP",
  "2Rt2P1Vh4o4GK5EwfqF8ndxscxRZErTuyV9",
  "Y1g9wuCKZjCArscCAdw2YjyWoiwv5Dgv7U",
  "2Fafftp7czxeoiio5bNHUN3WbfvrJPghVZn",
  "2W5K63cGj1DsvB7RkjmpM43PgajoJKemynv",
  "2JmV5HRoUcQY4qfBCfUFgg1GKSbAW24iFDP",
  "JWyJu3N51syANQWy8CR5H8UyoM1W4zHbja",
  "atsx4Dc6dnqoJQHKPDjR6hgjjEtF7cNhSw",
  "G6TVGZhGKttfCybksiQ77EYuQ6QUuXVsFs",
  "tnmiayXaehMjUutwQiMnjfwumiJii3Negi",
  "qKBvbpxDrCC13fJih6z786gYkCMfPr4yt9",
  "2Q3fiiv1VnZq52EXRegs7Zm2uNuN1VqYEr6",
  "2XTfvKh4sjavjxWzUpun2aEioprqmjy8DRg",
  "rDdVaVDJhB1idZHPXbQ3PmDFV1ieXp51hq",
  "5MyhUZ9JkQ8nNh11JManWvm8btNEmBDHm9",
  "2faGziNRteqfmS2iT2JHrqg3DGJCr7bwPuf",
  "s6nvRxY2XmgzUNxHPhpvZWL7KxgXHjpeEx",
  "i4NJfp663DS2BKoZqRrwZWyqJmhV49rWVM",
  "fcvhLM6vswQ1Gv6TjSjiadS6zoE7zDshJa",
  "nfSyJEW2ABm9W8vEQiRsrWEiFu7t68YkYc",
  "bQB98uNcaCJXWWeGr6x6xrGq5NMzbSfw7B",
  "242BmWuosWU4Sj5e3kvDQ6ibvzNqZUzZ4de",
  "26BWqf1QCBxGUdnbuonjWRi27LVVLmab2Z3",
  "MLXZvSFYD2Q3ST9hWHJK4wgMmoSCBW4cvi",
  "wdVZgcdoPVpdEhAM5SBQ4gm3aZQU5rbCjm",
  "22z6getjDD2GNjXZqe8tHjt5ypjutAEFoLo",
  "2GEFesXK5Uv14hn5Bmqwd61c1CCQGMvbZLh",
  "24zxvoEFNb6ww8zDnchMsqdBoJuBL2t6LQD",
  "2F9PfKBjsUMEViRoM1jKAG55T1fSu6hg1aU",
  "k6s7miNx1cnYVEgUPQD2iqufKzQpRDmzQ",
  "S8kVNfBsuRPY8UcwVC44L4JmHF9c2vdoz",
  "2ELFHvS8iJs7g9hAYmSQ4d3fPkHPZ7GSYb2",
  "hVeQGNagmE3VdB8FAipt4Ya792T7JhXruJ",
  "2gzCB5wvkKAAjind13d6r4oSm2wasV4aTjA",
  "6DhQZL3HQG1Ai4pH9c72G2Svy2ELaozDpH",
  "2Tw4op3FCi2aXuSySqPEkxUxAVHCi8Wyxwp",
  "2apYHtvxjoen5tFVrb88XkjPRHp61bnMmYF",
  "1NdzQhMertw6PGza5eSxqfWMhMjGhbYszx",
  "xQgKsD9dAHf3NAazojsQ8WYzbaAyrJZeVy",
  "2SShMG5rU7mJ7v6wsjtFYgxrNB56P3cpdrS",
  "M6JKu4bqGgnJ9ZFuodqfxdzN7Y4q6yoDYZ",
  "21vVXWwfSgmhVjMZKzRqQphhHWJhQN9PDmy",
  "HPju6EpzFnWijK4YF2PKhGw36zpC5MTPqc",
  "B4X6nsN8LUFZnyzPU3xuVJvJseVy5QFywn",
  "rA8hZGYDhU6mpYdXvwJwdMkCijiGHxGG22",
  "fHnsaH3e5F4iMSAaRBFdDvNuEXWMiG4h6z",
  "NpcgbvncaoAW2TZDbLvA3SgRBKGKjFBnss",
  "7mZibtJzH5BV7nTsk2L2E8ybPJQzXgsjjY",
  "rTrV5jQZ1116ubbxqTD3r9VVgd9bRausbm",
  "2HCBvVq4Z7rsJ7o3NdRGoG2DT1KZ5EinoD7",
  "2RUhPZhqiAoSiEYBrymsdAJ6t5VkEVV8sTc",
  "Avk4QuxAyeFr7VtchVebEY6Raz4uRs4UZM",
  "MGgcz3urE7CCqBm7BrUyiv5YgSkzM1zmAk",
  "2MYqwgpjcM4KooQG5kPE7nqicqqma8TPoQH",
  "ae8Ah32GU21Jk2K8ryWB3xdcyBmLZT7Gob",
  "Hft6JuhuFhKpQmCteJp4y63GHadLWbtP5m",
};

