
# Project Blueprint

## Overview

This document outlines the features and design of the Carengo application, a multi-functional mobile app for Libyan users. The app provides a web-based experience with access to offline features and social links.

## Application Flow

*   **Online State:** When the device has an active internet connection, the application displays the `carengo.com` website in a `WebView`. A Floating Action Button (FAB) is overlaid on the screen, allowing users to navigate to the "Features & More" screen.
*   **Offline State:** If the device is offline, the application directly displays the "Features & More" screen as the main interface.
*   **Connectivity Changes:** The app dynamically listens for connectivity changes. If the connection is lost, it switches to the offline view. If the connection is restored, it switches back to the online `WebView` and shows a "You are back online!" notification.

## Style and Design

*   **Theme:** The app uses a modern, clean design with a blue primary color.
*   **Typography:** Google Fonts are used for a consistent and readable text style.
*   **Icons:** Material Icons are used for intuitive navigation and actions.
*   **Layout:** The layout is designed to be responsive and work well on both mobile and web.

## Features

### Online Mode (WebView)

*   The main screen of the app is a webview that loads the Carengo website.
*   A Floating Action Button provides persistent access to the "Features & More" screen.

### Features & More Screen

This screen is accessible both online (via FAB) and offline (as the main screen). It contains:

*   **Daily Diary:**
    *   **Date-based Entries:** Users can create and save diary entries for each day.
    *   **Image Support:** Users can add a single image to each diary entry.
    *   **PIN Lock:** Entries can be locked with a PIN for privacy.
    *   **Deletion:** Entries can be deleted.

*   **2048 Game:**
    *   A classic 2048 puzzle game with swipe controls, scoring, and instructions.

*   **Chess Game:**
    *   A chess game where users can play against a computer AI with adjustable difficulty levels (Easy, Medium, Hard).

*   **Social Media Links:**
    *   Clickable icons for WhatsApp, Instagram, YouTube, and X (Twitter) that open the respective social media pages.

*   **Financial Support:**
    *   A button that initiates a USSD-based mobile money transfer for users to support the development studio.

## Current Plan

*   **Completed:** Application has been restructured to use a primary WebView with a Floating Action Button for accessing offline features. The offline experience is now the primary view when there is no internet connection.
*   **Next Steps:** Review and testing of the new application flow.

